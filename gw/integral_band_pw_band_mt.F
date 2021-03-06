      subroutine integral_band_pw_band_mt(fifi_j,ff,pn)
	use atom_mod
	use manager_mod
	use parallel_mod
	use solid_mod
	use units_mod
      implicit none
      real*8, intent(in) :: fifi_j(maxlfun,maxlfun,0:2*maxb,nspin,
     &                             nspin,nsort),pn(3)
	complex*16, intent(out) :: ff(maxel,maxel,natom,nspin,nspin)
      integer :: iatom,isort,ndimb,lm1,l1,lget,nm1,lm,l,nm,ii,iii,ispin,
     &           jspin,indx,icg1,icg2,icg,lmi,l_i,ie1,km1,lf1,ie,km,lf,
     &           in,jn,in1,jn1
	real*8 :: fas,q(3),qq,sqpi4,pi2
	complex*16 :: c1,c2
	real*8, allocatable :: ylm(:)
	allocate(ylm((2*maxb+1)**2))
	pi2=pi+pi
      sqpi4=sqrt(4.d0*pi)
	q=pn
	qq=sqrt(dot_product(q,q))
	if(qq.gt.1.d-9) then
	  call sphharm(q(1)/qq,q(2)/qq,q(3)/qq,2*maxb,ylm)
	else
	  ylm=0.d0
	  ylm(1)=1.d0/sqpi4
	endif
	ff=(0.d0,0.d0)
	do iatom=1,natom
	  isort=is(iatom)
	  ndimb=(lmb(isort)+1)**2
        fas=pi2*dot_product(pn,tau(:,iatom))
        c1=exp(dcmplx(0.d0,-fas))
	  do lm1=1,ndimb
	    l1=lget(lm1)
	    nm1=ntle(l1,isort)
	    do lm=1,ndimb
	      l=lget(lm)
	      nm=ntle(l,isort)
	      ii = max0(lm1,lm)
	      iii = min0(lm1,lm)
            indx = (ii*(ii-1))/2 + iii
            icg1 = indxcg(indx)
            icg2 = indxcg(indx+1) - 1 
            do icg = icg1, icg2
		      lmi = jcg(icg)
	        l_i=lget(lmi)
	        c2=c1*(0.d0,-1.d0)**l_i*ylm(lmi)*cg(icg)
		      do ie1=1,nm1
			    in1=1
			    if(augm(ie1,l1,isort)/='LOC') in1=2
			    do jn1=1,in1
	            km1=indbasa(jn1,ie1,lm1,isort)
	            lf1=lf_isz(km1,isort)
		          do ie=1,nm
			        in=1
			        if(augm(ie,l,isort)/='LOC') in=2
			        do jn=1,in
	                km=indbasa(jn,ie,lm,isort)
	                lf=lf_isz(km,isort)
	                do jspin=1,nspin
	                  do ispin=1,nspin
	                    ff(km,km1,iatom,ispin,jspin)=
     &	                    ff(km,km1,iatom,ispin,jspin)+c2
     &	                    *fifi_j(lf,lf1,l_i,ispin,jspin,isort)
	                  enddo
	                enddo
	              enddo   !! over jn
	            enddo   !! over ie
	          enddo   !!! over jn1
	        enddo   !! over ie1
	      enddo   !! over icg
	    enddo   !! over lm
	  enddo  !! over lm1
	enddo  !! over iatom
	deallocate(ylm)
      end